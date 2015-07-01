require 'spec_helper'
require 'restforce'

describe Salesforce do
  after { Salesforce.reset! }

  let(:config) do
    {
      "username" => "tim@gocardless.com",
      "password" => "password",
      "security_token" => "security_token",
      "client_id" => "client_id",
      "client_secret" => "client_secret"
    }
  end

  let(:exception_handler) { lambda { |method, exception, arguments| puts method } }

  it 'has a version number' do
    expect(Salesforce::VERSION).not_to be nil
  end

  describe "#client" do
    context "without a configuration provided" do
      it "raises an error" do
        expect { Salesforce.client }.to raise_error(Salesforce::MissingConfigError)
      end
    end

    context "with a configuration provided" do
      before { Salesforce.config = config }

      let(:symbolised_config) do
        config.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
      end

      it "returns a Restforce::Client" do
        expect(Salesforce.client).to be_a(Restforce::Client)
      end

      it "passes the config when creating the client" do
        expect(Restforce).to receive(:new).with(symbolised_config).and_call_original
        Salesforce.client
      end
    end
  end

  describe "#method_missing" do
    subject(:arbitrary_method) { Salesforce.arbitrary_method }

    before { Salesforce.config = config }
    before { Salesforce.exception_handler = exception_handler }

    it "delegates to the Restforce::Client" do
      expect_any_instance_of(Restforce::Client).to receive(:arbitrary_method).
        and_return(true)

      expect(arbitrary_method).to be(true)
    end

    context "Restforce::Client raises" do
      context "a Faraday::ClientError" do
        it "uses the provided exception handler" do
          expect_any_instance_of(Restforce::Client).to receive(:arbitrary_method).
            and_raise(Faraday::ClientError, status: 400, headers: [], body: "")

          expect(exception_handler).to receive(:call).
            with(:arbitrary_method, instance_of(Faraday::ClientError), [])

          arbitrary_method
        end
      end

      context "a Faraday::ResourceNotFound error" do
        it "re-raises" do
          expect_any_instance_of(Restforce::Client).to receive(:arbitrary_method).
            and_raise(Faraday::ResourceNotFound, status: 404, headers: [], body: "")

          expect { arbitrary_method }.to raise_error(Faraday::ResourceNotFound)
        end
      end

      context "another error" do
        it "re-raises" do
          expect_any_instance_of(Restforce::Client).to receive(:arbitrary_method).
            and_raise(ArgumentError, "Yadda yadda")

          expect { arbitrary_method }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
