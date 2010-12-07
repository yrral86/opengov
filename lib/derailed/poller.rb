require 'derailed/component/environment'
require 'derailed/component/view'

module Derailed
  class Poller
    include Component::Environment
    include Component::View

    def initialize
      @threads = {}
      @data = {}
      @mutexes = {}
    end

    def render(user_id, &block)
      if @data[user_id]
        # if there is data, return it
        yield @data.delete user_id
      elsif params['_need_cookie_update']
        # The poll was the first request after the session cache died,
        # return an empty response so the cookie updates and we can authenticate
        # any new requests
        yield ''
      else
        env = Thread.current[:env]
        # spawn response thread, sleep it
        @threads[user_id] = Thread.new do
          Thread.current[:env] = env
          # sleep until we are woken for request times out
          slept = sleep Derailed::Config::RequestTimeout
          # clean up thread
          @threads.delete(user_id)
          # check if we were woken, or timed out
          if slept< Derailed::Config::RequestTimeout
            yield @data.delete user_id
          else
            render_timeout
          end
        end

        @threads[user_id].value
      end
    end

    def renderable(user_id, data=true)
      @data[user_id] = data
      # on data receive, run long poll thread
      @threads[user_id].run if @threads[user_id] && @threads[user_id].alive?
    end
  end
end
