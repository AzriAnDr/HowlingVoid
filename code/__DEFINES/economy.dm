/// How much mail the Economy SS will create per minute, regardless of firing time.
#define MAX_MAIL_PER_MINUTE 3
/// Probability of using letters of envelope sprites on all letters.
#define FULL_CRATE_LETTER_ODDS 70

// Legacy paygrade constants. Howling Void uses per-job paycheck and starting_funds values for wages;
// these constants remain as compatibility price anchors for upstream content.
///Default paygrade for the Unassigned Job/Unpaid job assignments.
#define PAYCHECK_ZERO 0
///Legacy lower-tier price/paygrade anchor.
#define PAYCHECK_LOWER 25
///Legacy crew-tier price/paygrade anchor.
#define PAYCHECK_CREW 50
///Legacy command-tier price/paygrade anchor.
#define PAYCHECK_COMMAND 100
///The coefficient for the amount of dosh that's collected everytime some is earned or received.
#define DEBT_COLLECTION_COEFF 0.75

#define MAX_GRANT_DPT 500

//What should vending machines charge when you buy something in-department.
#define DEPARTMENT_DISCOUNT 0.2

//How much of a paid security fine is deposited into the issuing officer's bank account.
#define SECURITY_FINE_OFFICER_SHARE 0.3

//How much a detective earns for finding new forensic markers during a paid evidence analysis.
#define DETECTIVE_ANALYSIS_REWARD_PER_CATEGORY 1
//Maximum personal payout from a single paid evidence analysis.
#define DETECTIVE_ANALYSIS_REWARD_MAX 6

//How much a brig-authorized officer earns for processing a prisoner intake.
#define CORRECTIONS_INTAKE_REWARD 4
//Transaction reason for paid prisoner intake processing.
#define CORRECTIONS_INTAKE_TRANSACTION_REASON "Corrections: Prisoner intake"

//the amount of credits collected by the vending machines that can be redeemed when restocking it.
#define VENDING_CREDITS_COLLECTION_AMOUNT 0.2

#define MEDICAL_INSURANCE_START_DEFAULT 350
#define MEDICAL_INSURANCE_START_RISK 700
#define MEDICAL_INSURANCE_START_PRIORITY 1000
#define MEDICAL_INSURANCE_PAYDAY_RATE 0.1
#define MEDICAL_INSURANCE_TREATMENT_WINDOW (10 MINUTES)
#define MEDICAL_INSURANCE_CLAIM_COOLDOWN (20 MINUTES)
#define MEDICAL_INSURANCE_SCAN_LINK_TIME (30 SECONDS)
#define MEDICAL_INSURANCE_MIN_PAYOUT 10
#define MEDICAL_INSURANCE_MAX_PAYOUT 200
#define MEDICAL_INSURANCE_BASE_FEE 8
#define MEDICAL_INSURANCE_DAMAGE_TOLERANCE 0.5
#define MEDICAL_INSURANCE_DAMAGE_DIVISOR 3
#define MEDICAL_INSURANCE_EMBED_PRICE 5
#define MEDICAL_INSURANCE_EMBED_CAP 20
#define MEDICAL_INSURANCE_BLOOD_LOW_PRICE 10
#define MEDICAL_INSURANCE_BLOOD_CRITICAL_PRICE 25
#define MEDICAL_INSURANCE_BLOOD_SAFE_PERCENT 85
#define MEDICAL_INSURANCE_MISSING_LIMB_PRICE 45
#define MEDICAL_INSURANCE_NONFUNCTIONAL_ORGAN_PRICE 40
#define MEDICAL_INSURANCE_TEMP_MILD_PRICE 10
#define MEDICAL_INSURANCE_TEMP_SEVERE_PRICE 25
#define MEDICAL_INSURANCE_DISEASE_PRICE 20
#define MEDICAL_INSURANCE_DISEASE_CAP 60
#define MEDICAL_INSURANCE_DEATH_PRICE 60

#define ACCOUNT_CIV "CIV"
#define ACCOUNT_CIV_NAME "Civil Budget"
#define ACCOUNT_ENG "ENG"
#define ACCOUNT_ENG_NAME "Engineering Budget"
#define ACCOUNT_SCI "SCI"
#define ACCOUNT_SCI_NAME "Scientific Budget"
#define ACCOUNT_MED "MED"
#define ACCOUNT_MED_NAME "Medical Budget"
#define ACCOUNT_SRV "SRV"
#define ACCOUNT_SRV_NAME "Service Budget"
#define ACCOUNT_CAR "CAR"
#define ACCOUNT_CAR_NAME "Cargo Budget"
#define ACCOUNT_SEC "SEC"
#define ACCOUNT_SEC_NAME "Defense Budget"

#define IS_DEPARTMENTAL_CARD(card) (card in SSeconomy.dep_cards)
#define IS_DEPARTMENTAL_ACCOUNT(account) (account in SSeconomy.departmental_accounts)

#define NO_FREEBIES "commies go home"

/// The special account ID for admins using debug cards.
#define ADMIN_ACCOUNT_ID "ADMIN!"

//Defines that set what kind of civilian bounties should be applied mid-round.
#define CIV_JOB_BASIC 1
#define CIV_JOB_ROBO 2
#define CIV_JOB_CHEF 3
#define CIV_JOB_SEC 4
#define CIV_JOB_DRINK 5
#define CIV_JOB_CHEM 6
#define CIV_JOB_VIRO 7
#define CIV_JOB_SCI 8
#define CIV_JOB_ENG 9
#define CIV_JOB_MINE 10
#define CIV_JOB_MED 11
#define CIV_JOB_GROW 12
#define CIV_JOB_ATMOS 13
#define CIV_JOB_BITRUN 14
#define CIV_JOB_RANDOM 24 // NOVA EDIT CHANGE - ORIGINAL: CIV_JOB_RANDOM 15

#define MAXIMUM_BOUNTY_JOBS 24 // NOVA EDIT CHANGE - ORIGINAL: #define MAXIMUM_BOUNTY_JOBS 14 //Should be equal to the highest numbered non-random job above.

//These defines are to be used to with the payment component, determines which lines will be used during a transaction. If in doubt, go with clinical.
#define PAYMENT_CLINICAL "clinical"
#define PAYMENT_FRIENDLY "friendly"
#define PAYMENT_ANGRY "angry"
#define PAYMENT_VENDING "vending"

#define MARKET_TREND_UPWARD 1
#define MARKET_TREND_DOWNWARD -1
#define MARKET_TREND_STABLE 0

#define MARKET_EVENT_PROBABILITY 8 //Probability of a market event firing, in percent. Fires once per material, every stock market tick.

// Fair warning that these defines at present are not used in all tgui, static descriptions, or any varible names or comments
/// The symbol for the default type of money used in the code.
#define MONEY_SYMBOL "cr"
/// The name for the default type of money used in the code.
#define MONEY_NAME "credits"
#define MONEY_NAME_SINGULAR "credit"
#define MONEY_NAME_CAPITALIZED "Credits"
// Due to the ways macros work, I cant just directly use credit\s.
// You will need to verify there is no loose use cases of credit\s.
// As of present there is none left floating around.
#define MONEY_NAME_AUTOPURAL(amount) "credit[##amount == 1 ? "" : "s"]"

#define MONEY_MINING_SYMBOL "mp"
#define MONEY_BITRUNNING_SYMBOL "np"
