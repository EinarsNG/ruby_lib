# frozen_string_literal: true

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# rake "android[common/helper]"
describe 'common/helper' do
  wait_opts = { timeout: 0.2, interval: 0.2 } # max_wait, interval

  # There's no `must_not_raise` as the opposite of must_raise

  # By default code is expected to not raise exceptions.
  # must_not_raise is a no-op.

  # wait is a success unless an error is raised
  # max_wait=0 is infinity to use 0.1
  t 'wait' do
    # successful wait should not raise error
    wait(wait_opts) { true }
    wait(wait_opts) { false }
    wait(wait_opts) { nil }

    # failed wait should error
    proc { wait(wait_opts) { raise } }.must_raise ::Appium::Core::Wait::TimeoutError

    # regular rescue will not handle exceptions outside of StandardError hierarchy
    # must rescue Exception explicitly to rescue everything
    proc { wait(wait_opts) { raise NoMemoryError } }.must_raise ::Appium::Core::Wait::TimeoutError
    proc { wait(timeout: 0.2, interval: 0.0) { raise NoMemoryError } }.must_raise ::Appium::Core::Wait::TimeoutError

    proc { wait_true(invalidkey: 2) { true } }.must_raise ArgumentError do
      assert_equal 'unknown keyword: invalidkey', e.message
    end
  end

  t 'ignore' do
    # ignore should rescue all exceptions
    ignore { true }
    ignore { false }
    ignore { nil }
    ignore { raise }
    ignore { raise NoMemoryError }
  end

  # wait_true is a success unless the value is not true
  t 'wait_true' do
    # successful wait should not error
    wait_true(wait_opts) { true }

    # failed wait should error
    proc { wait_true(wait_opts) { false } }.must_raise ::Appium::Core::Wait::TimeoutError
    proc { wait_true(wait_opts) { nil } }.must_raise ::Appium::Core::Wait::TimeoutError

    # raise should error
    proc { wait_true(wait_opts) { raise } }.must_raise ::Appium::Core::Wait::TimeoutError

    # regular rescue will not handle exceptions outside of StandardError hierarchy
    # must rescue Exception explicitly to rescue everything
    proc { wait_true(wait_opts) { raise NoMemoryError } }.must_raise ::Appium::Core::Wait::TimeoutError
    proc { wait_true(timeout: 0.2, interval: 0.0) { raise NoMemoryError } }
      .must_raise ::Appium::Core::Wait::TimeoutError

    proc { wait_true(invalidkey: 2) { true } }.must_raise ArgumentError do
      assert_equal 'unknown keyword: invalidkey', e.message
    end
  end

  t 'back' do
    # start page
    wait { texts.length.must_equal 13 }
    # nav to new page.
    # ele 0 is the title and can't be clicked.
    wait { text(2).click }
    wait { texts.length.must_equal 5 }
    # go back
    back
    # start page
    wait { find 'NFC' }
  end

  t 'session_id' do
    wait { session_id.must_match(/\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/) }
  end

  t 'xpath' do
    #  Access'ibility is for Espresso
    wait { ['API Demos', "Access'ibility"].must_include xpath('//android.widget.TextView').text }
  end

  t 'xpaths' do
    wait { xpaths('//android.widget.TextView').length.must_equal 13 }
  end

  t 'ele_index' do
    # Animation is for Espresso
    wait { %w(Accessibility Animation).must_include ele_index('android.widget.TextView', 3).text }
  end

  t 'tags' do
    wait { tags('android.widget.TextView').length.must_equal 13 }
  end

  t 'first_ele' do
    wait do
      # Access'ibility is for Espresso
      ['API Demos', "Access'ibility"].must_include first_ele('android.widget.TextView').text
    end
  end

  t 'last_ele' do
    wait do
      # "API Demos" is for Espresso
      ['API Demos', 'Views'].must_include last_ele('android.widget.TextView').text
    end
  end

  # t 'source' do # tested by get_source

  t 'get_source' do
    wait do
      get_source.class.must_equal String
    end
  end
end
