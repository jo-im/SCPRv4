require 'spec_helper'

describe LogsAsTask do
  it 'logs the message' do
    # Just want to make sure we don't get errors, really.
    TestClass::TestLogger.log("This is a message.")
    log = TestClass::TestLogger.stdout_logger.instance_variable_get(:@logdev).dev.string
    log.should match /This is a message/
  end

  it 'can log from the instance as well' do
    TestClass::TestLogger.new.log("This is a message")
    log = TestClass::TestLogger.stdout_logger.instance_variable_get(:@logdev).dev.string
    log.should match /This is a message/
  end
end
