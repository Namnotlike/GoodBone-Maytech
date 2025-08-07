/*
Plugin Name: Maytech App API
Website: https://software.maytech.vn/
Description: This is a custom Maytech plugin
Version: 1.0.0
Author: Hang Le
*/

add_action('rest_api_init', 'wp_route_create');
function wp_route_create($request) {
  register_rest_route('route', 'create', array(
    'methods' => 'POST',
    'callback' => 'wp_route_create_handler',
  ));
}
function wp_route_create_handler($request = null) {
	global $wpdb;
	$response = array();
    $parameters = $request->get_json_params();
	
	if ( is_user_logged_in() && $parameters) {
		$user_id = get_current_user_id();//11
			global $wpdb;
			$query = "SELECT * FROM `as_customers` WHERE user_id = ".$user_id.";";
			$customer = $wpdb->get_row($query);
			if ($customer){
				//Check Balance points 
				if ($customer->balance > 0) {
					//TODO: Call API estimate
// 					
					$insertRoute = $wpdb->insert("as_routes", array(
						"route_status" => 1,
						"customer_id" => $customer->customer_id,
						"created_date" => current_datetime()->format('Y-m-d H:i:s'),
						"start_point" => $parameters['start_point'],
						"end_point" => $parameters['end_point'],
						"quantity" => $parameters['quantity'],
						"start_time" => $parameters['start_time'],
						"forecast_time" =>$parameters['forecast_time'],
						"end_time" => $parameters['end_time'],
						"weather" => "2023-11-01, Chance of showers\n2023-11-02, A mix of sun and cloud\n2023-11-03, Increasing cloudiness\n2023-11-04, Cloudy periods",
						"notes" => "Tonight: Partly cloudy. Becoming cloudy this evening with 60 percent chance of showers overnight. Risk of a thunderstorm overnight. Wind southwest 30 km/h gusting to 50 becoming northwest 20 gusting to 40 before morning. Low 12.",
					));
					if ( !$insertRoute ) {
						return array(
							'status' => 'fail',
							'title' => __( 'Error!', 'wp_route_create' ),
							'message' => __( 'Insert Route Errors!', 'wp_route_create' )
						);
					}
					
					$newRouteId = $wpdb->insert_id;
					$balance_remain = $customer->balance - 1;
					//Insert Transaction 
					$insertTransaction = $wpdb->insert('as_transactions', array(
						"transaction_status" => 1,
						"transaction_type" => 2, //1 = Add, //2=Route
						"transaction_date" => current_datetime()->format('Y-m-d H:i:s'),
						"customer_id" => $customer->customer_id,
						"ref_id" => $newRouteId,
						"title" => "Add new route",
						"body" => "Transaction Details",
						"value" => -1,
						"balance_remain" => $balance_remain,
					));
					
					if ( !$insertTransaction ) {
						return array(
							'status' => 'fail',
							'title' => __( 'Error!', 'wp_route_create' ),
							'message' => __( 'Insert Transaction Errors!', 'wp_route_create' )
						);
					}
					
// 					update customer balance
					$updateCustomer = $wpdb->update('as_customers', array('balance'=>$balance_remain), array('customer_id'=>$customer->customer_id));
					
					if ( !$updateCustomer ) {
						return array(
							'status' => 'fail',
							'title' => __( 'Error!', 'wp_route_create' ),
							'message' => __( 'Update Customer Balance Errors!', 'wp_route_create' )
						);
					}
					
					$queryNewRoute = "SELECT * FROM `as_routes` WHERE route_id = ".$newRouteId.";";
					$newRoute = $wpdb->get_row($queryNewRoute);
						return array(
							'status' => 'success',
							'obj' => __( $newRoute, 'wp_route_create' )
						);
				} else {
					return array(
						'status' => 'fail',
						'title' => __( 'Error!', 'wp_route_create' ),
						'message' => __( 'Over points!', 'wp_route_create' )
					);
				}
			} else {
				return array(
					'status' => 'fail',
					'title' => __( 'Error!', 'wp_route_create' ),
					'message' => __( 'Can not find Customer!', 'wp_route_create' )
				);
			}
	}
	
		return array(
				'status' => 'fail',
				'title' => __( 'Error!', 'wp_route_create' ),
				'message' => __( 'Request failed. User is not logged in or invalid parameters!', 'wp_route_create' )
		);
}

add_action( 'rest_api_init', function () {
register_rest_route( 'route', 'list', array(
      'methods' => 'GET',
      'callback' => 'wp_route_get_list_handler',
    ) );
});
function wp_route_get_list_handler($data) {
	if ( is_user_logged_in()) {
		$page_size = $data->get_param( 'page_size' );//get_query_var('page_size');// $request->get_url_params( 'page_size' );
		if ($page_size == null){
			$page_size = 10;
		}
		$page_no = $data->get_param( 'page_no' );//get_query_var('page_no');//$request->get_url_params( 'page_no' );
		if ($page_no == null){
			$page_no = 0;
		}
		$offset = $page_no * $page_size;
		
		$user_id = get_current_user_id();//11
		global $wpdb;
		$query = "SELECT * FROM `as_customers` WHERE user_id = ".$user_id.";";
		$customer = $wpdb->get_row($query);
		if ($customer){
			$query = "SELECT * FROM `as_routes` WHERE customer_id = ".$customer->customer_id." and route_status = 1 ORDER BY route_id desc LIMIT ".$offset.", ".$page_size.";";
			$list = $wpdb->get_results($query);	
			return $list;
		} else {
			return array(
				'status' => 'fail',
				'title' => __( 'Error!', 'wp_route_create' ),
				'message' => __( 'Can not find Customer!', 'wp_route_create' )
			);
		}
	}
	
	return array(
		'status' => 'fail',
		'title' => __( 'Error!', 'wp_route_create' ),
		'message' => __( 'Request failed. User is not logged in or invalid parameters!', 'wp_route_create' )
	);
}

add_action( 'rest_api_init', function () {
register_rest_route( 'route', 'transactions', array(
      'methods' => 'GET',
      'callback' => 'wp_route_get_transactions_handler',
    ) );
});
function wp_route_get_transactions_handler($data) {
	if ( is_user_logged_in()) {
		$page_size = $data->get_param( 'page_size' );//get_query_var('page_size');// $request->get_url_params( 'page_size' );
		if ($page_size == null){
			$page_size = 10;
		}
		$page_no = $data->get_param( 'page_no' );//get_query_var('page_no');//$request->get_url_params( 'page_no' );
		if ($page_no == null){
			$page_no = 0;
		}
		$offset = $page_no * $page_size;
		
		$user_id = get_current_user_id();//11
		global $wpdb;
		$query = "SELECT * FROM `as_customers` WHERE user_id = ".$user_id.";";
		$customer = $wpdb->get_row($query);
		if ($customer){
			$query = "SELECT * FROM `as_transactions` WHERE customer_id = ".$customer->customer_id." and transaction_status = 1 ORDER BY transaction_id desc LIMIT ".$offset.", ".$page_size.";";
			$list = $wpdb->get_results($query);	
			return $list;
		} else {
			return array(
				'status' => 'fail',
				'title' => __( 'Error!', 'wp_route_create' ),
				'message' => __( 'Can not find Customer!', 'wp_route_create' )
			);
		}
	}
	
	return array(
		'status' => 'fail',
		'title' => __( 'Error!', 'wp_route_create' ),
		'message' => __( 'Request failed. User is not logged in or invalid parameters!', 'wp_route_create' )
	);
}

add_action('rest_api_init', function () {
register_rest_route( 'route', 'balance', array(
      'methods' => 'GET',
      'callback' => 'wp_route_get_balance_handler',
    ) );
});
function wp_route_get_balance_handler($request = null) {
	if ( is_user_logged_in()) {
		$user_id = get_current_user_id();//11
		global $wpdb;
		$query = "SELECT c.*, p.title as package_name FROM `as_customers` c INNER JOIN `as_packages` p ON c.current_package = p.package_id WHERE c.user_id = ".$user_id.";";
		$customer = $wpdb->get_row($query);
		return $customer;
	}
	
	return 0;
}
