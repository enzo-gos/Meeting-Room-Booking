class User < ApplicationRecord
  rolify
  after_create :assign_default_role

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         omniauth_providers: [:google_oauth2]

  has_many :teams, through: :user_teams

  def self.from_google(user_params)
    create_with(uid: user_params[:uid], password: Devise.friendly_token[0, 20], provider: 'google').find_or_create_by!(email: user_params[:email])
  end

  def assign_default_role
    add_role(:user) if roles.blank? || !has_role?(:user)
  end
end
