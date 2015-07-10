require_relative '../spec_helper'

WSTRUST_FIXTURES = File.expand_path('../../fixtures/wstrust', __FILE__)

describe ADAL::WSTrustResponse do
  describe '::parse' do
    let(:response) { File.read(File.expand_path(file_name, WSTRUST_FIXTURES)) }

    context 'with a successful response' do
      let(:file_name) { 'success.xml' }

      let(:token) do
        File.read(File.expand_path('token.xml', WSTRUST_FIXTURES))
      end

      it 'correctly extracts the token' do
        wstrust_response = ADAL::WSTrustResponse.parse(response)
        expect(wstrust_response.token.strip).to eq(token.strip)
      end

      it 'has the correct grant type' do
        wstrust_response = ADAL::WSTrustResponse.parse(response)
        expect(wstrust_response.grant_type).to eq(
          ADAL::TokenRequest::GrantType::SAML1)
      end
    end

    context 'with an error response' do
      let(:file_name) { 'error.xml' }

      it 'throws the appropriate error' do
        expect do
          ADAL::WSTrustResponse.parse(response)
        end.to raise_error(ADAL::WSTrustResponse::WSTrustResponseError)
      end
    end
  end

  describe '#grant_type' do
    context 'with a SAML1 token type' do
      subject do
        response = ADAL::WSTrustResponse.new(
          'irrelevant', ADAL::WSTrustResponse::TokenType::V1)
        response.grant_type
      end
      it { is_expected.to eq(ADAL::TokenRequest::GrantType::SAML1) }
    end

    context 'with a SAML2 token type' do
      subject do
        response = ADAL::WSTrustResponse.new(
          'irrelevant', ADAL::WSTrustResponse::TokenType::V2)
        response.grant_type
      end
      it { is_expected.to eq(ADAL::TokenRequest::GrantType::SAML2) }
    end

    # This case should not happen unless the developer is being intentionally
    # hacky. The constructor ensures that the token type is valid.
    context 'with an unrecognized token type' do
      subject do
        response = ADAL::WSTrustResponse.new(
          'irrelevant', ADAL::WSTrustResponse::TokenType::V1)
        response.instance_variable_set(:@token_type, 'not a token type')
        response.grant_type
      end
      it { is_expected.to be_nil }
    end
  end
end
