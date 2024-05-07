# == Schema Information
#
# Table name: departments
#
#  id          :bigint           not null, primary key
#  name        :string
#  description :string
#  address     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Department < ApplicationRecord
end
