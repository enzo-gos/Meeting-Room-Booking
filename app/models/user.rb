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

  has_many :teams, through: :user_teams

  def self.from_google(user_params)
    create_with(uid: user_params[:uid], password: Devise.friendly_token[0, 20], provider: 'google').find_or_create_by!(email: user_params[:email])
  end

  def current_password_is_correct
    if User.find(id).valid_password?(current_password) == false
      errors.add("Current password is incorrect.")
    end
  end

  def validate_password?
    !password.blank?
  end

  def assign_default_role
    add_role(:user) if roles.blank? || !has_role?(:user)
  end

  attr_accessor :current_password
end
