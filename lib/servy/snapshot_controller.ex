defmodule Servy.SnapshotController do
  alias Servy.Conv
  alias Servy.SnapshotView
  alias Servy.VideoCam

  def snapshots(%Conv{} = conv) do
    task = Task.async(Servy.Tracker, :get_location, ["bigfoot"])

    snapshots = ["cam1", "cam2", "cam3", "cam4"]
    |> Enum.map(& Task.async(VideoCam, :get_snapshot, [&1]))
    |> Enum.map(& Task.await(&1))

    bigfoot_location = Task.await(task)

    %{ conv | status: 200, resp_body:  SnapshotView.snapshot(snapshots, bigfoot_location)}
  end
end
