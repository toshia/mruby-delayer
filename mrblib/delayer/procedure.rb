# -*- coding: utf-8 -*-

module Delayer
  class Procedure
    attr_reader :state, :delayer
    attr_accessor :next
    def initialize(delayer, &proc)
      @delayer, @proc = delayer, proc
      @state = :stop
      @next = nil
      @delayer.class.register(self)
    end

    # Run a process
    # ==== Exception
    # Delayer::TooLate :: if already called run()
    # ==== Return
    # node
    def run
      unless :stop == @state
        raise Delayer::StateError(@state), "call twice Delayer::Procedure"
      end
      @state = :run
      @proc.call
      @state = :done
      @proc = nil
    end

    # Cancel this job
    # ==== Exception
    # Delayer::TooLate :: if already called run()
    # ==== Return
    # self
    def cancel
      unless :stop == @state
        raise Delayer::StateError(@state), "cannot cancel Delayer::Procedure"
      end
      @state = :cancel
      self
    end

    # Return true if canceled this task
    # ==== Return
    # true if canceled this task
    def canceled?
      :cancel == @state
    end

    # insert node between self and self.next
    # ==== Args
    # [node] insertion
    # ==== Return
    # node
    def break(node)
      tail = @next
      @next = node
      node.next = tail
      node
    end
  end
end
