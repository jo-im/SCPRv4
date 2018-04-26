require 'timeout'
require 'open3'
module Embeditor
  class Processor
    attr_accessor :stdin, :stdout
    class EmbeditorError < StandardError; end
    def initialize options={}
      args = []
      options.each_pair do |k, v|
        v = nil if v == true
        args << "--#{[k, v].compact.join('-')}"
      end
      @arguments = args.join(" ")
      open
    end
    def process html
      Timeout.timeout(5) do
        @stdin.write html
        # We expect to receive at least an EOT byte from both stdout and stderr
        output, error = [@stdout.gets("\x04"), @stderr.gets("\x04")]
          .map{|o| (o || '').gsub("\x04", "")}
          .map{|o| o.blank? ? nil : o}
        unless error
          raise EmbeditorError.new("No output received.") if output.blank?
          return output.gsub("\x04", "") # remove our "end of transmission" signifier
        else
          raise EmbeditorError.new(error)
        end
      end
    rescue Timeout::Error, EmbeditorError, Errno::EPIPE => e
      close
      open
      html # just return original markup in case of failure
    end
    def reload
      close
      open
    end
    def open
      @stdin, @stdout, @stderr, @wait_thr = Open3.popen3("node_modules/portable-holes/bin/portable-holes #{@arguments}")
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
      @stdin  = nil
      @stdout = nil
      @stderr = nil
      @wait_thr.value if @wait_thr # Process::Status object returned.
    end
  end
end