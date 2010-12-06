require 'derailed/poller'

class AjaxController < Derailed::Component::Controller
  def initialize(component, manager)
    super(component, manager)
    @test_poller = Derailed::Poller.new
  end

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
      run_js(code), binding
  end

  def stream
    render_block do |buffer|
      i = 0
      10.times do
        buffer.write i
        sleep 1
        i += 1
      end
    end
  end

  def poller
    render_string <<eof
#{run_js "poll_to_div('content','/ajax/poll');"}
empty
eof
  end

  def add_data
    user_id = @component.current_user.id
    @test_poller.renderable(user_id, params['data'])
    render_string "data #{params['data']} added"
  end

  def poll
    user_id = @component.current_user.id
    @test_poller.render(user_id) do |data|
      render_string data
    end
  end
end
