defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  test "should create pledges" do
    pid = PledgeServer.start()

    PledgeServer.create_pledge("duncan", 1)
    PledgeServer.create_pledge("victoria", 1)
    PledgeServer.create_pledge("isaiah", 1)
    PledgeServer.create_pledge("nathan", 1)
    PledgeServer.create_pledge("annabelle", 1)
    PledgeServer.create_pledge("kenneth", 1)

    assert Process.whereis(:pledge_server) == pid
    assert PledgeServer.recent_pledges() == [{"kenneth", 1}, {"annabelle", 1}, {"nathan", 1}]
    assert PledgeServer.total_pledged() == 3
  end
end
