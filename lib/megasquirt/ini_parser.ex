defmodule Megasquirt.IniParser do
  require Logger

  def parse_file(filename) do
    filename
    |> read_file()
    |> split_binary()
    |> remove_comments()
    |> preprocess()
    |> process_headers()
    |> process_key_values()
  end

  defp process_key_values(list_of_headers_and_strings) do
    Enum.map(list_of_headers_and_strings, fn {header, strings} ->
      {header, Task.async(fn -> do_process_key_values(strings) end)}
    end)
    |> Enum.map(fn {header, task} ->
      case Task.await(task) do
        [_ | _] = value -> {header, value}
        error -> raise("error processing key values in headr: #{header}: #{inspect(error)}")
      end
    end)
  end

  defp do_process_key_values(strings, acc \\ [])

  defp do_process_key_values([str | rest], acc) do
    [key | value] = String.split(str, "=")

    value =
      Enum.map(value, &String.trim/1)
      |> Enum.join(" ")
      |> String.split(",")
      |> Enum.map(&String.trim/1)

    v = {String.trim(key), value}
    do_process_key_values(rest, [v | acc])
  end

  defp do_process_key_values([], acc), do: Enum.reverse(acc)

  defp process_headers(list_of_strs, acc \\ [])

  defp process_headers(["[" <> _ = section_header | rest], acc) do
    ["", section_header] = String.split(section_header, "[")
    [section_header, ""] = String.split(section_header, "]")
    process_headers(rest, [{section_header, []} | acc])
  end

  defp process_headers([str | rest], [{header, buffer} | acc]) do
    process_headers(rest, [{header, buffer ++ [str]} | acc])
  end

  defp process_headers([], acc), do: Enum.reverse(acc)

  defp read_file(filename), do: File.read!(filename)

  defp split_binary(binary) do
    String.split(binary, "\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&match?("", &1))
  end

  defp remove_comments(list_of_strs, acc \\ [])

  defp remove_comments([";" <> _ | rest], acc), do: remove_comments(rest, acc)

  defp remove_comments([str | rest], acc) do
    [str | _] = String.split(str, ";")
    remove_comments(rest, [str | acc])
  end

  defp remove_comments([], acc), do: Enum.reverse(acc)

  defp preprocess(list_of_strs, acc \\ [], env \\ [])

  defp preprocess(["#set " <> set_cmd | rest], acc, env) do
    env = preprocess_set(set_cmd, env)
    preprocess(rest, acc, env)
  end

  defp preprocess(["#unset " <> unset_cmd | rest], acc, env) do
    env = preprocess_unset(unset_cmd, env)
    preprocess(rest, acc, env)
  end

  defp preprocess(["#if " <> if_cmd | rest], acc, env) do
    evaluated = preprocess_if(if_cmd, rest, env)
    preprocess(evaluated, acc, env)
  end

  defp preprocess(["#ifdef " <> if_cmd | rest], acc, env) do
    evaluated = preprocess_if(if_cmd, rest, env)
    preprocess(evaluated, acc, env)
  end

  defp preprocess(["#error " <> error_str | rest], acc, env) do
    Logger.error("INI Error: #{error_str}")
    preprocess(rest, acc, env)
  end

  defp preprocess(["#define" <> _ | rest], acc, env) do
    # TODO(Connor) - implement define
    preprocess(rest, acc, env)
  end

  defp preprocess(["#9" <> _ | rest], acc, env) do
    # TODO(Connor) what the hell is this???
    preprocess(rest, acc, env)
  end

  defp preprocess(["#endif" <> _ | rest], acc, env) do
    # TODO(Connor) do nothing on extra endif?
    preprocess(rest, acc, env)
  end

  defp preprocess(["#" <> unknown_cmd | _rest], _acc, _env) do
    raise("unknown preprocessor command: #{unknown_cmd}")
  end

  defp preprocess([str | rest], acc, env) do
    preprocess(rest, [str | acc], env)
  end

  defp preprocess([], acc, _env) do
    Enum.reverse(acc)
  end

  defp preprocess_set(cmd, env) do
    case String.split(String.trim(cmd), " ") do
      [name] -> [{name, true} | env]
      [name, value] -> [{name, value} | env]
    end
  end

  defp preprocess_unset(cmd, env) do
    List.keydelete(env, String.trim(cmd), 0)
  end

  defp preprocess_if(name, list_of_strs, env) do
    {to_process, rest} = enumerate_if(list_of_strs, [{:if, String.trim(name), []}])
    evaluate_if(to_process, env) ++ rest
  end

  defp enumerate_if(list_of_strs, if_buffer)

  defp enumerate_if(["#elif " <> condition | rest], if_buffer) do
    enumerate_if(rest, [{:elif, String.trim(condition), []} | if_buffer])
  end

  defp enumerate_if(["#else" <> _ | rest], if_buffer) do
    enumerate_if(rest, [{:else, nil, []} | if_buffer])
  end

  defp enumerate_if(["#endif" <> _ | rest], if_buffer) do
    {Enum.reverse(if_buffer), rest}
  end

  defp enumerate_if([str | rest], [{kind, condition, buffer} | if_buffer]) do
    enumerate_if(rest, [{kind, condition, buffer ++ [str]} | if_buffer])
  end

  defp evaluate_if([{:if, condition, result} | rest], env) do
    if List.keyfind(env, condition, 0) do
      IO.inspect(result, label: "#if #{condition}")
      result
    else
      evaluate_if(rest, env)
    end
  end

  defp evaluate_if([{:elif, condition, result} | rest], env) do
    if List.keyfind(env, condition, 0) do
      IO.inspect(result, label: "#elif #{condition}")
      result
    else
      evaluate_if(rest, env)
    end
  end

  defp evaluate_if([{:else, _, result} | _rest], _env) do
    IO.inspect(result, label: "#else")
    result
  end

  # no condition evalutated true
  defp evaluate_if([], _env), do: []
end
