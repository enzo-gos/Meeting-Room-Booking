# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  firstname              :string
#  lastname               :string
#  provider               :string
#  uid                    :string
#
class User < ApplicationRecord
  rolify
  has_one_attached :avatar
  after_create :assign_default_role

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         omniauth_providers: [:google_oauth2]

  validate :current_password_is_correct,
           if: :validate_password?, on: :update

  has_many :meeting_reservations, foreign_key: :book_by_id
  has_and_belongs_to_many :teams

  validates :team_ids, presence: true
  validates :role_ids, presence: true

  def self.from_google(user_params)
    user = nil
    if User.where(email: user_params[:email]).exists?
      user = create_with(uid: user_params[:uid], password: Devise.friendly_token[0, 20], provider: 'google').find_or_create_by!(email: user_params[:email])
    end
    user
  end

  def current_password_is_correct
    if User.find(id).valid_password?(current_password) == false
      errors.add('Current password is incorrect.')
    end
  end

  def validate_password?
    !password.blank? && !current_password.blank?
  end

  def assign_default_role
    add_role(:user) if roles.blank? || !has_role?(:user)
  end

  def admin?
    has_role?(:admin)
  end

  attr_accessor :current_password
end
