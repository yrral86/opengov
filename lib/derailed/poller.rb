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
      user_id = user_id.to_i
      if @data[user_id]
        # if there is data, return it
        return yield @data.delete user_id
      elsif params['_need_cookie_update']
        # The poll was the first request after the session cache died,
        # return an empty response so the cookie updates and we can authenticate
        # any new requests
        return yield ''
      else
        @mutexes[user_id] = Mutex.new
        @threads[user_id] = Thread.current
        # sleep until we are woken or request times out
        sleep Config::RequestTimeout
        # clean up thread
        @mutexes[user_id].synchronize do
          @threads.delete(user_id)
          # check if we have data, or timed out
          if @data[user_id]
            yield @data.delete user_id
          else
            render_timeout
          end
        end        
      end
    end

    def renderable(user_id, data=true)
      user_id = user_id.to_i
      @data[user_id] = data if data
      # on data receive, run long poll thread if it exists
      test = false
      t = nil
      @mutexes[user_id].synchronize do
        t = @threads[user_id]
        test = t && t.alive?
      end if @mutexes[user_id]
      if test
        t.wakeup
#        t.join
      end
    end

    def reset_user(user_id)
      user_id = user_id.to_i
      @data.delete user_id
      renderable(user_id, false)
      @mutexes[user_id].synchronize do
        @threads.delete user_id
      end if @mutexes[user_id]
      @mutexes.delete user_id
    end
  end
end
