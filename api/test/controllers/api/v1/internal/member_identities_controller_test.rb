# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    module Internal
      class MemberIdentitiesControllerTest < ActionDispatch::IntegrationTest
        setup do
          @organization = create(:organization, slug: "mega")
          @user = create(:user, username: "alice_campsite", github_login: "alice-gh")
          create(:organization_membership, organization: @organization, user: @user)
          @secret = "a" * 32
          ENV["MEGA_INTERNAL_SECRET"] = @secret
        end

        teardown do
          ENV.delete("MEGA_INTERNAL_SECRET")
        end

        test "returns member identities with valid secret" do
          get organization_internal_member_identities_path(org_slug: "mega"),
            headers: {"X-Mega-Internal-Secret" => @secret}

          assert_response :success
          body = response.parsed_body
          assert_kind_of Array, body
          row = body.find { |r| r["username"] == "alice_campsite" }
          assert_not_nil row
          assert_equal @user.public_id, row["campsite_user_id"]
          assert_equal "alice-gh", row["github_login"]
        end

        test "rejects missing secret" do
          get organization_internal_member_identities_path(org_slug: "mega")
          assert_response :unauthorized
        end

        test "rejects wrong secret" do
          get organization_internal_member_identities_path(org_slug: "mega"),
            headers: {"X-Mega-Internal-Secret" => "wrong-secret-value-xxxxxxxx"}
          assert_response :unauthorized
        end
      end
    end
  end
end
