class AjaxController < Derailed::Component::Controller
  def initialize(component, manager)
    super(component, manager)
    @polling_threads = {}
    @polling_data = {}
    @polling_mutexes = {}
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
<script type="text/javascript">
poll_to_div('content','/ajax/poll');
</script>
empty
eof
  end

  def add_data
    user_id = @component.current_user.id
    @polling_data[user_id] = params['data']
    # on data receive, wake up thread
    @polling_threads[user_id].run if @polling_threads[user_id] &&
      @polling_threads[user_id].alive?
    render_string "data #{params['data']} added"
  end

  def poll
    user_id = @component.current_user.id

    if @polling_data[user_id]
      # if there is data return it
      render_data user_id
    elsif params['_need_cookie_update']
      # The poll was the first request after the session cache died,
      # return an empty response so the cookie updates and we can authenticate
      # any new requests
      render_string ''
    else
      env = Thread.current[:env]

      # spawn response thread, sleep it
      @polling_threads[user_id] = Thread.new do
        response = nil
        Thread.current[:env] = env
        slept = sleep Derailed::Config::RequestTimeout
        @polling_threads.delete(user_id)
        if slept < Derailed::Config::RequestTimeout
          render_data user_id
        else
          render_timeout
        end
      end

      @polling_threads[user_id].value
    end
  end

  private
  def render_data(user_id)
    data = @polling_data[user_id]
    @polling_data.delete user_id
    render_string data
  end
end
