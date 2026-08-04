# frozen_string_literal: true

module Api
  module V1
    module Internal
      # Service-to-service member identity map for mono actor backfill.
      # Auth: X-Mega-Internal-Secret matching ENV["MEGA_INTERNAL_SECRET"] (no user session).
      class MemberIdentitiesController < ActionController::API
        include RequestRescuable
        include RequestReturnable

        before_action :authenticate_mega_internal!

        def index
          organization = Organization.find_by!(slug: params[:org_slug])
          identities = organization.kept_memberships.eager_load(:user).filter_map do |membership|
            user = membership.user
            next if user.blank?

            {
              campsite_user_id: user.public_id,
              username: user.username,
              github_login: user.github_login,
            }
          end

          render(json: identities)
        end

        private

        def authenticate_mega_internal!
          expected = ENV.fetch("MEGA_INTERNAL_SECRET", "").to_s
          provided = request.headers["X-Mega-Internal-Secret"].to_s

          unless expected.present? && provided.present? && secure_equals?(expected, provided)
            render(
              json: {code: "unauthorized", message: "Invalid or missing X-Mega-Internal-Secret"},
              status: :unauthorized,
            )
          end
        end

        def secure_equals?(a, b)
          return false if a.bytesize != b.bytesize

          ActiveSupport::SecurityUtils.secure_compare(a, b)
        end
      end
    end
  end
end
