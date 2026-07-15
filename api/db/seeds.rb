# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
if Rails.env.development?
  # Create development Zapier app. This maps to the `Campsite (Dev)` app in our Zapier account.
  OauthApplication.create(
    name: "Zapier",
    provider: :zapier,
    avatar_path: "static/avatars/service-zapier.png",
    redirect_uri: Rails.application.credentials.zapier.redirect_uri,
    confidential: true,
    scopes: "read_organization write_organization",
    uid: Rails.application.credentials.zapier.client_id,
    secret: Doorkeeper.config.application_secret_strategy.transform_secret(Rails.application.credentials.zapier.client_secret),
  )

  OauthApplication.create(
    name: "Cal.com",
    provider: :cal_dot_com,
    avatar_path: "static/avatars/service-cal-dot-com.png",
    redirect_uri: Rails.application.credentials.cal_dot_com.redirect_uri,
    confidential: true,
    uid: Rails.application.credentials.cal_dot_com.client_id,
    secret: Doorkeeper.config.application_secret_strategy.transform_secret(Rails.application.credentials.cal_dot_com.client_secret),
  )

  # Set up the default dev org (users + memberships). Content seeding is best-effort.
  generator = DemoOrgs::Generator.new

  admin_member = generator.admin_membership
  admin_user = admin_member.user

  # Make Rick "staff" (a private Campsite property - allows admin access, among other things)
  admin_user.update!(staff: true)

  # Mega org + join token used by moon auto-join (must match production plaintext /
  # moon/apps/web/middleware.ts and pages/index.tsx). Encrypt with local AR keys —
  # do not paste production ciphertext into SQL.
  mega_join_token = "s3AX1iyAx3sgGNygiM67"
  mega = Organization.find_by(slug: "mega")
  mega ||= Organization.create_organization(creator: admin_user, name: "Mega", slug: "mega")
  mega.update!(invite_token: mega_join_token) if mega.invite_token != mega_join_token
  mega.create_membership!(user: admin_user, role_name: :admin) unless mega.member?(admin_user)

  begin
    generator.update_content
  rescue StandardError => e
    warn "[seeds] DemoOrgs content seeding skipped: #{e.class}: #{e.message}"
  end

  # Create an empty organization
  unless Organization.exists?(slug: "deserted-dunes")
    alt_org = Organization.create_organization(creator: admin_user, name: "Deserted Dunes", slug: "deserted-dunes")
    alt_org.create_membership!(user: admin_user, role_name: :admin)
  end

  OauthApplication.create(
    name: "figma-plugin",
    provider: :figma,
    redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
    confidential: true,
    owner: admin_user,
    scopes: "read_organization write_post write_project"
  )
end
