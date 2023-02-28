defmodule Servy.SnapshotView do
  require EEx

  @templates_path Path.expand("../../templates", __DIR__)

  EEx.function_from_file :def, :snapshot, Path.join(@templates_path, "snapshots.eex"), [:snapshots, :bigfoot_location]
end
