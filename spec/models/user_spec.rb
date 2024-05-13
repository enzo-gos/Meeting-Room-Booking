# spec/models/user_spec.rb

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user_google_params) { { email: 'user@example.com', uid: '1234567890' } }
  let(:user) { User.new(email: 'user@example.com', password: 'password', provider: 'google', uid: '1234567890', current_password: 'password') }

  before do
    user.save!
  end

  it 'can be saved' do
    expect(user).to be_valid
  end

  it 'cannot be saved without an email' do
    user.email = nil
    expect(user).not_to be_valid
  end

  it 'password must be at least 6 characters long' do
    user.password = 'short'
    expect(user).not_to be_valid
  end

  it 'email must be unique' do
    duplicate_user = User.new(email: 'user@example.com', password: 'password', firstname: 'John', lastname: 'Doe', provider: 'google_oauth2', uid: '1234567890', current_password: 'password')
    duplicate_user.save
    expect(User.where(email: 'user@example.com').count).to eq(1)
  end

  # Test case for assign_default_role
  it 'assigns the default role if none is assigned' do
    user.remove_role(:admin)
    expect(user.has_role?(:user)).to be true
  end

  # Test case for admin?
  it 'returns true if the user has the admin role' do
    user.add_role :admin
    expect(user.admin?).to be true
  end

  it 'logs in with Google; if the user does not exist, creates a new one' do
    user = User.from_google(user_google_params)

    expect(user).to be_persisted
    expect(user.email).to eq(user_google_params[:email])
    expect(user.provider).to eq('google')
  end

  it 'validates current password when updating the profile' do
    user.current_password = 'wrongpassword'
    user.current_password_is_correct
    expect(user.errors).to include('Current password is incorrect.')
  end
end
