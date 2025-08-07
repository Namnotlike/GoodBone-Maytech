<?php

/**

 * The base configuration for WordPress

 *

 * The wp-config.php creation script uses this file during the installation.

 * You don't have to use the web site, you can copy this file to "wp-config.php"

 * and fill in the values.

 *

 * This file contains the following configurations:

 *

 * * Database settings

 * * Secret keys

 * * Database table prefix

 * * ABSPATH

 *

 * @link https://wordpress.org/support/article/editing-wp-config-php/

 *

 * @package WordPress

 */



// ** Database settings - You can get this info from your web host ** //

/** The name of the database for WordPress */

define( 'DB_NAME', 'ltestocking_smartsocks' );



/** Database username */

define( 'DB_USER', 'ltestocking_smartsocks' );



/** Database password */

define( 'DB_PASSWORD', 'DbbvQ#9LfkK' );



/** Database hostname */

define( 'DB_HOST', 'localhost' );



/** Database charset to use in creating database tables. */

define( 'DB_CHARSET', 'utf8mb4' );



/** The database collate type. Don't change this if in doubt. */

define( 'DB_COLLATE', '' );



/**#@+

 * Authentication unique keys and salts.

 *

 * Change these to different unique phrases! You can generate these using

 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.

 *

 * You can change these at any point in time to invalidate all existing cookies.

 * This will force all users to have to log in again.

 *

 * @since 2.6.0

 */

define( 'AUTH_KEY',         '!D0:-9eq;[7Ek-KbsXsqU7d%mT[g{R@W~LOK@fZDny#D]mMCqUm#D5cYTx]KK!ag' );

define( 'SECURE_AUTH_KEY',  'cO}VOQcDIFB$}c2YU>*%HML4U/W*uzn)B$Vxs*~CJr<%w.vW 7]F7q7iyW.lxlml' );

define( 'LOGGED_IN_KEY',    '`0a EGN%2 ~;w-}~>^2gd%*1,_ysf/ w!ra]pjTT#I|NN/H`Gp`ep_4wr$o?o)~~' );

define( 'NONCE_KEY',        '9!;8W^)F`2lZxcuqfr@jDz1-_vzM3d0]{dl4@OEjIJ%:%I<*o.NUL2y=%~$.IKOA' );

define( 'AUTH_SALT',        'vu`(`*zl}oo$NYwfr3@[rjH3~kVJWXq7t8OeT~[vBIT,8<A&<,<B(-M,olqzgr.G' );

define( 'SECURE_AUTH_SALT', 'Fw*H}j5y6=Ab I61Aw+Y/zyi[,P9Dr_*_eub5Sw$SScw8HSpHJ2yO:fUCL(XtK6#' );

define( 'LOGGED_IN_SALT',   '-5P_`)xSG]32cXjZ|j8^rW,oj%t3g`L04_4T=InnGYLV$_At 7~xD<T~5JsDj7rh' );

define( 'NONCE_SALT',       'plRa~!}iiv|*}*cw^.#IH+G&IIz?5Qy#U0659)dKacO7.uq/ ]wF3]2;o6I$? cx' );



/**#@-*/



/**

 * WordPress database table prefix.

 *

 * You can have multiple installations in one database if you give each

 * a unique prefix. Only numbers, letters, and underscores please!

 */

$table_prefix = 'ss_';



/**

 * For developers: WordPress debugging mode.

 *

 * Change this to true to enable the display of notices during development.

 * It is strongly recommended that plugin and theme developers use WP_DEBUG

 * in their development environments.

 *

 * For information on other constants that can be used for debugging,

 * visit the documentation.

 *

 * @link https://wordpress.org/support/article/debugging-in-wordpress/

 */

define( 'WP_DEBUG', false );
define('JWT_AUTH_SECRET_KEY', 'a)Yb|_(LG W=6F;vuxT]Qs2&@QbU%*}gR}@Qj~~&Z#hF`57;|50kcnVa[n7TO^n|');
define('JWT_AUTH_CORS_ENABLE', true);


/* Add any custom values between this line and the "stop editing" line. */







/* That's all, stop editing! Happy publishing. */



/** Absolute path to the WordPress directory. */

if ( ! defined( 'ABSPATH' ) ) {

	define( 'ABSPATH', __DIR__ . '/' );

}



/** Sets up WordPress vars and included files. */

require_once ABSPATH . 'wp-settings.php';

