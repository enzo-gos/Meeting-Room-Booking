# == Schema Information
#
# Table name: rooms
#
#  id            :bigint           not null, primary key
#  name          :string
#  department_id :bigint           not null
#  max_capacity  :integer
#  description   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
