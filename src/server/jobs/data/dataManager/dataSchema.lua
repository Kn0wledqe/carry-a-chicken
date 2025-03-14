return {
	wins = 0,
	coins = 0,
	revives = 0,

	spins = 0,
	lastAwardedSpin = 0,

	nukes = 0,
	invites = 0,

	hasVip = false,
	infiniteRevives = false,
	doubleWingStrength = false,
	favorited = false,

	dailyRewards = {
		rewardPathID = "NEW2025",
		rewardIndex = 1,
		rewardsClaimedIndex = 0,
		rewardTick = workspace:GetServerTimeNow()
			- (if game:GetService("RunService"):IsStudio() then 15 else 60 * 60 * 24),
	},

	skins = { 1 },
	equippedSkin = 1,

	effects = {
		-- [PotionID] = timeUntilExpires
	},

	potions = {},

	settings = {
		music = false,
		sfx = false,
	},

	purchaseHistory = {},

	playtime = 0,
	sessions = 0,
}
