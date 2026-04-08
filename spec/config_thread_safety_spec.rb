# frozen_string_literal: true

# Config.disable must only suppress randomization in the calling thread.
# Before the fix, @enabled was a class-level variable shared across threads,
# so one thread's disable block would suppress randomization in all threads.

RSpec.describe Unreliable::Config, "thread safety" do
  it "does not affect other threads when disabled" do
    other_thread_sql = nil
    barrier = Queue.new

    Unreliable::Config.disable do
      # Our thread has randomization disabled
      expect(Cat.all.to_sql).to_not include("RANDOM()")
      expect(Cat.all.to_sql).to_not include("RAND()")

      Thread.new do
        other_thread_sql = Cat.all.to_sql
        barrier.push(:done)
      end

      barrier.pop # wait for the other thread
    end

    expect(other_thread_sql).to include(adapter_rand("RANDOM()"))
  end
end
