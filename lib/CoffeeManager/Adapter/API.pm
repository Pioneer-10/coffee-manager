package CoffeeManager::Adapter::API;

use strict;
use warnings;
use utf8;

=head1 NAME

CoffeeManager::Adapter::API - implementation of HTTP API layer for the CoffeeManager application

=cut

use Plack::Response;

use CoffeeManager::Encoder::JSON;
use CoffeeManager::Error::API;
use CoffeeManager::Error::NotFound;
use CoffeeManager::View::API::CaffeineLevelHistory;
use CoffeeManager::View::API::CoffeeHistory;
use CoffeeManager::View::API::ErrorResponse;
use CoffeeManager::View::API::NewRow;

use constant ENCODER_CLASS => 'CoffeeManager::Encoder::JSON';
use constant METHOD_VIEW_CLASS => {
	'register_user' => 'CoffeeManager::View::API::NewRow',
	'add_coffee_machine' => 'CoffeeManager::View::API::NewRow',
	'buy_some_coffee' => 'CoffeeManager::View::API::NewRow',
	'register_some_coffee' => 'CoffeeManager::View::API::NewRow',
	'get_stats_coffee' => 'CoffeeManager::View::API::CoffeeHistory',
	'get_stats_caffeine_level' => 'CoffeeManager::View::API::CaffeineLevelHistory',
};


sub new {
	my $class = shift;
	my $dbh = shift;
	my $action_class = shift;

	return bless {
		'_dbh' => $dbh,
		'_action_class' => $action_class,
	}, ref($class) || $class;
}

sub dbh {
	my $self = shift;
	return $self->{'_dbh'};
}

sub action_class {
	my $self = shift;
	return $self->{'_action_class'};
}

sub handle_request {
	my $self = shift;
	my $request = shift;
	my $method_name = shift;
	my $captures = shift;
	my $arguments = shift;

	my $adapter = $self->action_class->new($self->dbh);

	unless ($adapter->can($method_name)) {
		return $self->handle_error(CoffeeManager::Error::NotFound->new(method => $method_name));
	}

	my $params = $self->extract_parameters($request)
	or return $self->handle_error($self->error);

	if (my @params = grep { $_ } $captures, $arguments) {
		$params = { map { %$_ } $params, @params };
	}

	my $data = $adapter->$method_name($params);

	if (my $err = $adapter->error) {
		return $self->handle_error($err);
	}

	# wrap data into HTTP response
	my $view = $self->get_view_class_for_method($method_name)->new($data);
	my $encoder = $self->ENCODER_CLASS->new;

	my $response = Plack::Response->new(200);
	$response->content_type($encoder->MIME_TYPE);
	$response->body($encoder->encode($view));

	return $self->handle_error($encoder->error) if ($encoder->error);

	return $response->finalize;
}

sub extract_parameters {
	my $self = shift;
	my $request = shift;

	return {} unless ($self->request_has_payload($request));

	my $encoder = $self->ENCODER_CLASS->new;
	my $data = $encoder->decode($request->content);
	if (my $err = $encoder->error) {
		return $self->error($err);
	}

	unless ($data && ref($data) eq 'HASH') {
		return $self->error(CoffeeManager::Error::API->new("JSON object expected. Got: @{[ ref($data) ]}"))
	}
	return $data;
}

sub get_view_class_for_method {
	my $self = shift;
	my $method_name = shift;

	return METHOD_VIEW_CLASS->{$method_name};
}

sub request_has_payload {
	my $self = shift;
	my $request = shift;

	return ($request->env->{'REQUEST_METHOD'} =~ /^(?:GET|OPTIONS|HEAD)$/i) ? 0 : 1;
}

sub handle_error {
	my $self = shift;
	my $err = shift;

	my $view = CoffeeManager::View::API::ErrorResponse->new($err);
	my $encoder = $self->ENCODER_CLASS->new;

	my $response = Plack::Response->new($view->http_code);
	$response->content_type($encoder->MIME_TYPE);
	$response->body($encoder->encode($view));

	return $response->finalize;
}

sub error {
	my $self = shift;

	unless (scalar(@_)) {
		return $self->{'_error'};
	}
	$self->{'_error'} = shift;
	return
}

1;
