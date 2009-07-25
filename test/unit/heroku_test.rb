require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../lib/provisional/scm/heroku'

class HerokuTest < Test::Unit::TestCase
  def setup
    @scm = new_scm(Provisional::SCM::Heroku)
  end

  def test_checkin
    stub_git_checkin do |stub|
      stub.expects(:add_remote)
      stub.expects(:push)
      stub.expects(:remote).with('heroku')
    end

    stub_heroku do |stub|
      stub.expects(:create).returns(true)
    end

    @scm.checkin
  end

  def test_checkin_should_fail_if_heroku_credentials_are_missing
    File.expects(:open).with(File.join(ENV['HOME'],'.heroku','credentials'),'r').raises(RuntimeError)
    assert_raise RuntimeError do
      @scm.checkin
    end
  end

  def test_checkin_should_fail_if_heroku_credentials_are_not_in_expected_format
    File.expects(:open).with(File.join(ENV['HOME'],'.heroku','credentials'),'r').returns(stub(:readlines => %w(pants)))
    assert_raise RuntimeError do
      @scm.checkin
    end
  end

  def test_checkin_should_fail_if_any_step_raises_any_exception
    stub_git_checkin

    stub_heroku do |stub|
      stub.expects(:create).raises(RuntimeError)
    end

    assert_raise RuntimeError do
      @scm.checkin
    end
  end

  private

  def stub_heroku
    credentials = stub(:readlines => %w(username password))
    File.expects(:open).with(File.join(ENV['HOME'],'.heroku','credentials'),'r').returns(credentials)
    heroku = stub
    ::Heroku::Client.expects(:new).with('username', 'password').returns(heroku)
    yield heroku
  end
end
