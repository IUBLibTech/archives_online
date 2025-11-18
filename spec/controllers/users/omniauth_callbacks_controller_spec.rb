# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller, omni: true do
  include Devise::Test::ControllerHelpers

  before do
    User.create(provider: 'cas',
                uid: 'jim_watson')
    request.env['devise.mapping'] = Devise.mappings[:user]
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:cas]
  end
  OmniAuth.config.mock_auth[:cas] =
    OmniAuth::AuthHash.new(
      provider: 'cas',
      uid: 'jim_watson'
    )

  # If a user logs in it will redirect to admin page
  context 'with authenticated user' do
    it 'redirects to origin' do
      post :cas
      expect(response.redirect_url).to eq 'http://test.host/admin'
    end
  end
end