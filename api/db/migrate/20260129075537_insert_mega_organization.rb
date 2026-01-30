class InsertMegaOrganization < ActiveRecord::Migration[7.2]
  def up
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
        '{"p":"UraltlnPtlQ0htiWNJEGhXCadOc=","h":{"iv":"vAv4ARH1eZBisB61","at":"sw4RnNBOEnYW0L28q1eGJQ=="}}',
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

end
