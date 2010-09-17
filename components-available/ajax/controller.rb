class AjaxController < Derailed::Component::Controller
  def table
    render_string <<eof
<table>
  <tr><th>Column 1</th><th>Column 2</th><th>Column 3</th></tr>
  <tr><td>Data 1,1</td><td>Data 2,1</td><td>Data 3,1</td></tr>
  <tr><td>Data 1,2</td><td>Data 2,2</td><td>Data 3,2</td></tr>
  <tr><td>Data 1,3</td><td>Data 2,3</td><td>Data 3,3</td></tr>
  <tr><td>Data 1,4</td><td>Data 2,4</td><td>Data 3,4</td></tr>
  <tr><td>Data 1,5</td><td>Data 2,5</td><td>Data 3,5</td></tr>
</table>
eof
  end

  def updatable_table
    code = "update_div('table','/ajax/table')"
    render_erb '<div id="table"></div>' +
      a("javascript:#{code}", 'update') +
      "<script type=\"text/javascript\">#{code}</script>", binding
  end
end
