class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         omniauth_providers: [:google_oauth2]
  has_many :roles, through: :user_roles
  has_many :teams, through: :user_teams

  def self.from_google(user_params)
    role = Role.find_or_create_by(name: 'USER')

    new_user = create_with(uid: user_params[:uid], provider: 'google').find_or_create_by!(email: user_params[:email])
    UserRole.create(role_id: role.id, user_id: new_user.id)

    new_user
  end
end
