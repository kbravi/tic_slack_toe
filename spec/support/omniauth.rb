require 'faker'

OmniAuth.config.test_mode = true

def valid_omniauth_mock_auth_slack(preset = {})
  OmniAuth.config.add_mock(
    :slack,
    {
      provider: "slack",
      uid: Faker::Code.asin,
      credentials: {
        expires: false,
        token: Faker::Crypto.sha256,
      },
      extra: {
        bot_info: {},
        raw_info: {
          ok: true,
          team: preset[:team_name] || Faker::Company.name,
          team_id: preset[:slack_identifier] || Faker::Code.asin,
          url: Faker::Internet.url,
          user: Faker::Name.first_name,
          user_id: Faker::Code.asin
        },
        team_info: {
          ok: true,
          team: {
            domain: Faker::Internet.domain_name,
            email_domain: Faker::Internet.domain_name,
            icon: {
              image_102: Faker::Placeholdit.image,
              image_132: Faker::Placeholdit.image,
              image_23: Faker::Placeholdit.image,
              image_34: Faker::Placeholdit.image,
              image_44: Faker::Placeholdit.image,
              image_68: Faker::Placeholdit.image,
              image_88: Faker::Placeholdit.image,
              image_default: true
            },
            id: preset[:slack_identifier] || Faker::Code.asin,
            name: preset[:team_name] || Faker::Company.name
          }
        }
      }
    }
  )
  request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:slack] if request.present?
  Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
end

def invalid_omniauth_mock_auth_slack
  OmniAuth.config.mock_auth[:slack] = :invalid
  request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:slack] if request.present?
  Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
end
