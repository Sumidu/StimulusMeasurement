void endStudy() {

  filename = fullPath;
  selectOutput("Select a file to write to:", "fileSelected", f);

  Table table = new Table();
  table.addColumn("id");
  table.addColumn("user-id");
  table.addColumn("rating");
  table.addColumn("timing");
  for (int i=0; i < ratings.size(); i ++) {
    TableRow newRow = table.addRow();
    newRow.setInt("id", table.getRowCount() - 1);
    newRow.setString("user-id", user);
    newRow.setInt("rating", ratings.get(i));
    newRow.setLong("timing", timings.get(i));
  }
  saveTable(table, filename);
  println("Saved to:" + filename);

  state = -1;
}

void fileSelected(File selection) {
  if (selection == null) {
    selectOutput("Select a file to write to:", "fileSelected", f);
  } else {
    filename = selection.getAbsolutePath();
  }
}