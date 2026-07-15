# frozen_string_literal: true

require "session_cookie/logger"

ActionDispatch::Cookies::EncryptedKeyRotatingCookieJar.prepend(SessionCookie::Logger::EncryptedCookieLogging)
ActionDispatch::Cookies::SignedKeyRotatingCookieJar.prepend(SessionCookie::Logger::SignedCookieLogging)
