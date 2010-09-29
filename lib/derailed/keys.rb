module Derailed
  class Keys
    def initialize
      @mutex = Mutex.new
      @hash = {:exists => true}
      @threads = []
    end

    # TODO this will need a better algorithm to scale
      # binary tree of remaining keys, take a random walk?
    # we probably need a boatload of keys for this to bottleneck though
    def gen
      key = :exists
      @mutex.synchronize do
        key = rand(2*31) while @hash[key]
        @hash[key] = true
      end
      key
    end

    def []=(key, value)
      @threads[key] = value
    end

    def [](key)
      @threads[key]
    end

    def exists?(key)
      @hash[key]
    end

    def free(key)
      Thread.new do
        @mutex.synchronize do
          @hash.delete(key)
        end
        thread = @threads[key]
        if thread
          @threads.delete(key)
          thread.kill
        end
      end
    end
  end
end
