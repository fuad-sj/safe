customer_order_history.dart
    read: FIRESTORE_PATHS.COL_CUSTOMERS/{currentUser!.uid}/FIRESTORE_PATHS.SUB_COL_CUSTOMERS_RIDE_HISTORY       // self

customer_profile_screen.dart
    read + write: FIRESTORE_PATHS.COL_CUSTOMERS/{currentUser!.uid}      // self

main_screen_customer.dart
    read: FIRESTORE_PATHS.COL_CUSTOMERS/{currentUser!.uid}/FIRESTORE_PATHS.SUB_COL_CUSTOMERS_RIDE_HISTORY       // self
    read + write: FIRESTORE_PATHS.COL_CUSTOMERS/{currentUser!.uid}          // self
    read: FIRESTORE_PATHS.COL_UPDATE_VERSIONS/{FIRESTORE_PATHS.DOC_UPDATE_VERSIONS_CUSTOMERS}/FIRESTORE_PATHS.SUB_COL_UPDATE_VERSION_CUSTOMERS
    write: FIRESTORE_PATHS.COL_RIDES
    read: FIRESTORE_PATHS.COL_CONFIG/{FIRESTORE_PATHS.DOC_CONFIG}
    read: FIRESTORE_PATHS.COL_DRIVERS/{driver_id}       // driver_id is changeable

registration_screen.dart
    write: FIRESTORE_PATHS.COL_CUSTOMERS/{firebaseUser.uid}     // self

verify_otp_page.dart
    read: FIRESTORE_PATHS.COL_CUSTOMERS/{firebaseUser.uid}      // self

welcome_screen.dart
    read: FIRESTORE_PATHS.COL_CUSTOMERS/{firebaseUser.uid}      // self

activate_referral_code_bottom_sheet
    write: FIRESTORE_PATHS.COL_REFERRAL_REQUEST

cash_out_dialog.dart
    write: FIRESTORE_PATHS.COL_REFERRAL_PAYMENT_REQUESTS

ride_cancellation_dialog.dart
    write: FIRESTORE_PATHS.COL_RIDES

trip_summary_dialog.dart
    read + write: FIRESTORE_PATHS.COL_DRIVERS      
    write: FIRESTORE_PATHS.COL_RIDES

cash_out_screen.dart
    read: FIRESTORE_PATHS.COL_CUSTOMERS/{firebaseUser.uid}      // self
    read: FIRESTORE_PATHS.COL_REFERRAL_CURRENT_BALANCE/{firebaseUser.uid}      // self
    read: FIRESTORE_PATHS.COL_CONFIG/FIRESTORE_PATHS.DOC_CONFIG

main_payment_screen.dart
    read + write: FIRESTORE_PATHS.COL_CUSTOMERS/{firebaseUser.uid}      // self
    read + write: FIRESTORE_PATHS.COL_REFERRAL_TRAVERSED_TREE/{firebaseUser.uid}
    read: FIRESTORE_PATHS.COL_FLAT_REFERRAL_TREE
    read: FIRESTORE_PATHS.COL_REFERRAL_DAILY_EARNINGS
    read: FIRESTORE_PATHS.COL_CUSTOMERS/{customer_id}      // NOT self, OTHER
    read: FIRESTORE_PATHS.COL_REFERRAL_CURRENT_BALANCE/{firebaseUser.uid}       // self

recent_transaction_screen.dart
    read: FIRESTORE_PATHS.COL_REFERRAL_TRANSACTION_LOG          // where ReferralTransactionLog.TRANS_USER_ID == {firebaseUser.uid}
    // check if its possible to do a where based security rule



#########################################################
##
## Merged
##
#########################################################

# Customers

read: FIRESTORE_PATHS.COL_CUSTOMERS/
read: FIRESTORE_PATHS.COL_CUSTOMERS/{self_id}/FIRESTORE_PATHS.SUB_COL_CUSTOMERS_RIDE_HISTORY       // self
read: FIRESTORE_PATHS.COL_UPDATE_VERSIONS/{FIRESTORE_PATHS.DOC_UPDATE_VERSIONS_CUSTOMERS}/FIRESTORE_PATHS.SUB_COL_UPDATE_VERSION_CUSTOMERS
read: FIRESTORE_PATHS.COL_CONFIG/{FIRESTORE_PATHS.DOC_CONFIG}
read: FIRESTORE_PATHS.COL_DRIVERS/
read: FIRESTORE_PATHS.COL_REFERRAL_CURRENT_BALANCE/{self_id}      // self
read: FIRESTORE_PATHS.COL_FLAT_REFERRAL_TREE
read: FIRESTORE_PATHS.COL_REFERRAL_DAILY_EARNINGS
read: FIRESTORE_PATHS.COL_REFERRAL_TRAVERSED_TREE/{self_id}

write: FIRESTORE_PATHS.COL_CUSTOMERS/{self_id}      // self
write: FIRESTORE_PATHS.COL_DRIVERS      
write: FIRESTORE_PATHS.COL_REFERRAL_TRAVERSED_TREE/{self_id}        // self
write: FIRESTORE_PATHS.COL_RIDES
write: FIRESTORE_PATHS.COL_REFERRAL_REQUEST
write: FIRESTORE_PATHS.COL_REFERRAL_PAYMENT_REQUESTS

