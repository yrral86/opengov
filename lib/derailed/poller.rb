require 'derailed/component/environment'
require 'derailed/component/view'

module Derailed
  class Poller
    include Component::Environment
    include Component::View

    def initialize
      @threads = {}
      @data = {}
    end

    def render(user_id, &block)
      if @data[user_id]
        # if there is data, return it
        return yield @data.delete user_id
      elsif params['_need_cookie_update']
        # The poll was the first request after the session cache died,
        # return an empty response so the cookie updates and we can authenticate
        # any new requests
        return yield ''
      else
        env = Thread.current[:env]
        # spawn response thread, sleep it
        t = @threads[user_id] = Thread.new do
          Thread.current[:env] = env
          # sleep until we are woken or request times out
          sleep Config::RequestTimeout
          # clean up thread
          @threads.delete(user_id)
          # check if we have data, or timed out
          if @data[user_id]
            yield @data.delete user_id
          else
            render_timeout
          end
        end
        t.value
      end
    end

    def renderable(user_id, data=true)
      @data[user_id] = data if data
      # on data receive, run long poll thread if it exists
      if @threads[user_id] && @threads[user_id].alive?
        t = @threads[user_id]
        t.wakeup
        t.join
      end
    end

    def reset_user(user_id)
      @data.delete user_id
      renderable(user_id, false)
      @threads.delete user_id
    end
  end
end
