# frozen_string_literal: true

module SessionCookie
  module Logger
    SESSION_COOKIE_KEY = ENV.fetch("SESSION_COOKIE_KEY", "_campsite_api_session")

    module EncryptedCookieLogging
      private

      def parse(name, encrypted_message, purpose: nil)
        result = super(name, encrypted_message, purpose: purpose)

        if result.nil? && SessionCookie::Logger.session_cookie?(name) && encrypted_message.present?
          SessionCookie::Logger.log_encrypted_decryption_failure(self, request, name, encrypted_message, purpose: purpose)
        end

        result
      end
    end

    module SignedCookieLogging
      private

      def parse(name, signed_message, purpose: nil)
        result = super(name, signed_message, purpose: purpose)

        if result.nil? && SessionCookie::Logger.session_cookie?(name) && signed_message.present?
          SessionCookie::Logger.log_signed_verification_failure(self, request, name, signed_message, purpose: purpose)
        end

        result
      end
    end

    class << self
      def session_cookie?(name)
        name.to_s == SESSION_COOKIE_KEY
      end

      def log_encrypted_decryption_failure(jar, request, cookie_name, encrypted_message, purpose:)
        jar.send(:@encryptor).decrypt_and_verify(encrypted_message, purpose: purpose)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage => error
        log_invalid(request, cookie_name, "invalid_message", error)
      rescue ActiveSupport::MessageVerifier::InvalidSignature => error
        log_invalid(request, cookie_name, "invalid_signature", error)
      end

      def log_signed_verification_failure(jar, request, cookie_name, signed_message, purpose:)
        jar.send(:@verifier).verify(signed_message, purpose: purpose)
      rescue ActiveSupport::MessageVerifier::InvalidSignature => error
        log_invalid(request, cookie_name, "invalid_signature", error)
      end

      def log_invalid(request, cookie_name, reason, error)
        request.set_header("action_dispatch.invalid_session_cookie", reason)
        request.set_header("action_dispatch.invalid_session_cookie_key", cookie_name)

        Rails.logger.warn(
          "[session_cookie] invalid cookie " \
          "reason=#{reason} " \
          "key=#{cookie_name} " \
          "path=#{request.path} " \
          "method=#{request.request_method} " \
          "host=#{request.host} " \
          "ip=#{request.remote_ip} " \
          "error=#{error.class}: #{error.message}",
        )
      end
    end
  end
end
