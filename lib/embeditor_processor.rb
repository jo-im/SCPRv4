require 'timeout'
require 'open3'
module Embeditor
  class Processor
    attr_accessor :stdin, :stdout
    class EmbeditorError < StandardError; end
    def initialize
      open
    end
    def process html
      Timeout.timeout(5) do
        @stdin.write html
        while (output = @stdout.gets("\x04")) || (error = @stderr.gets("\x04"))
          unless error
            return output.gsub("\x04", "") # remove our "end of transmission" signifier
          else
            raise EmbeditorError.new(error)
          end
        end
      end
      output
    rescue Timeout::Error, EmbeditorError, Errno::EPIPE => e
      puts e
      close
      open
      html # just return original markup in case of failure
    end
    def open
      @stdin, @stdout, @stderr, @wait_thr = Open3.popen3("bin/embeditor")
      @pid = @wait_thr.pid
    end
    def closed?
      !@wait_thr.status
    end
    def close
      begin
        Process.kill("KILL", @pid) if @pid
      rescue Errno::ESRCH
        # Process is already dead so do nothing.
      end
      @wait_thr.value if @wait_thr # Process::Status object returned.
    end
  end
end