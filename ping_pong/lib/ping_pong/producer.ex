defmodule PingPong.Producer do
  @moduledoc """
  Sends pings to consumer processes
  """
  use GenServer

  alias PingPong.Consumer

  @initial %{current: 0}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def send_ping(server \\ __MODULE__) do
    GenServer.call(server, :send_ping)
  end

  def get_counts(server \\ __MODULE__) do
    GenServer.call(server, :get_counts)
  end

  def init(_args) do
    :net_kernel.monitor_nodes(true)
    {:ok, @initial}
  end

  def handle_call(:get_current, from, %{current: current} = state) do
    {:reply, current, state}
  end

  def handle_call(:send_ping, from, data) do
    GenServer.abcast(Consumer, {:ping, data.current+1, Node.self()})
    {:reply, :ok, %{data | current: data.current+1}}
  end

  def handle_call(:get_counts, _from, data) do
    map =
      Consumer
      |> GenServer.multi_call(:total_pings)
      |> Kernel.elem(0)
      |> Enum.into(%{})
    {:reply, map, data}
  end

  # Don't remove me :)
  def handle_call(:flush, _, _) do
    {:reply, :ok, @initial}
  end

  # Node callbacks
  def handle_info({:nodeup, node}, data) do
    # TODO - Fill me in l8r
    #IO.inspect msg, label: "Producer handle_info ::: msg"
    #IO.inspect data, label: "Producer handle_info ::: data"
    GenServer.abcast(Consumer, {:ping, data.current, node})
    {:noreply, data}
  end
  def handle_info({:nodedown, node}, data) do
    # TODO - Fill me in l8r
    #IO.inspect msg, label: "Producer handle_info ::: msg"
    #IO.inspect data, label: "Producer handle_info ::: data"
    GenServer.abcast(Consumer, {:ping, data.current, node})
    {:noreply, data}
  end
end

