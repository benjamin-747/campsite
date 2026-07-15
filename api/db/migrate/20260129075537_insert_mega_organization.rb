# frozen_string_literal: true

# Seeds the Mega org used by moon auto-join (`middleware.ts` / `pages/index.tsx`).
# Invite token plaintext must match production / frontend hardcode: s3AX1iyAx3sgGNygiM67.
# Encrypt with the current environment's ActiveRecord keys (do NOT paste production ciphertext).
class InsertMegaOrganization < ActiveRecord::Migration[7.2]
  MEGA_JOIN_TOKEN = "s3AX1iyAx3sgGNygiM67"

  def up
    return if connection.select_value("SELECT 1 FROM organizations WHERE slug = 'mega' LIMIT 1")

    encrypted_token = Organization.new(invite_token: MEGA_JOIN_TOKEN).ciphertext_for(:invite_token)

    execute <<~SQL
      INSERT INTO organizations (
        id,
        public_id,
        name,
        slug,
        email_domain,
        billing_email,
        avatar_path,
        slack_channel_id,
        invite_token,
        creator_id,
        onboarded_at,
        created_at,
        updated_at,
        plan_name,
        member_count,
        demo,
        creator_role,
        creator_org_size,
        trial_ends_at,
        creator_source,
        creator_why
      ) VALUES (
        1,
        'mnj33qd1tbfx',
        'Mega',
        'mega',
        null,
        'yetianxing2014@gmail.com',
        null,
        null,
        #{connection.quote(encrypted_token)},
        1,
        null,
        '2025-05-21 09:17:53.777353',
        '2025-05-21 09:17:53.777353',
        'pro',
        1,
        0,
        'software-engineer',
        '1000+',
        '2025-06-04 09:17:53.751165',
        'google',
        'Please enter your purpose.'
      );
    SQL
  end

  def down
    execute "DELETE FROM organizations WHERE slug = 'mega'"
  end
end
