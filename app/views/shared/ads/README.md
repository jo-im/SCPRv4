## Google DFP Targeting

`views/shared/ads/_dfp_script_config.html.erb` is a snipppet that is imported at the head of multiple layouts across SCPR.org. If a valid category and tag is passed in, it stores those values in JavaScript values that get processed in `views/shared/header/_ad_scripts_.html.erb`. This allows for category and tag-level targeting so that we can target campaigns in a more granular way. For example, if we wanted to target articles tagged with "The Affordable Care Act", we would specify that target in DFP, and the resulting campaign should be flighted in the top, middle, bottom position of that page (depending on which one the ad ops developer chooses).