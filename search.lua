local _, ns = ...

local Search = LibStub('CustomSearch-1.0')
local Filters = {}

function ns.Find(target, search)
	return Search(target, search, Filters)
end

Filters.abstract = {
	tags = {'n', 'name', 't', 'title', 'c', 'comment'},
	canSearch = function(self, operator, search)
		return not operator and search
	end,
	match = function(self, target, _, search)
		local data = string.join(' ', target.title or '', target.comment or '')
		return Search:Find(search, data)
	end
}
Filters.leader = {
	tags = {'l', 'leader', 'lead'},
	canSearch = function(self, operator, search)
		return not operator and search
	end,
	match = function(self, target, _, search)
		local name, realm, battleTag = ns.oq.DecodeLeaderData( target.leader )
		local _, realm = ns.GetRealmInfoByID(realm)
		local data = string.join(' ', name or '', realm or '', battleTag or '')
		return Search:Find(search, data)
	end
}
Filters.realm = {
	tags = {'r', 'rlm', 'realm'},
	canSearch = function(self, operator, search)
		return not operator and search
	end,
	match = function(self, target, _, search)
		local _, realm = ns.oq.DecodeLeaderData( target.leader )
		local _, realm, locale = ns.GetRealmInfoByID(realm)
		local data = string.join(' ', realm or '', locale or '')
		return Search:Find(search, data)
	end
}
Filters.realmtype = { -- TODO: fixme
	canSearch = function(self, _, search)
		return self.keywords[search]
	end,
	match = function(self, target, _, search)
		local _, realm = ns.oq.DecodeLeaderData( target.leader )
		local realm = ns.GetRealmInfoByID(realm, true)
		return search and realm[search]
	end,
	keywords = {
    	['rp']  = true,
    	['pvp'] = true,
	}
}
Filters.grouped = {
	tags = {'g', 'group', 'grouped', 'size'},
	canSearch = function(self, operator, search)
		return tonumber(search)
	end,
	match = function(self, target, operator, groupSize)
		return Search:Compare(operator, target.size, groupSize)
	end
}
Filters.waiting = {
	tags = {'q', 'queue', 'queued', 'w', 'waiting'},
	canSearch = function(self, operator, search)
		return tonumber(search)
	end,
	match = function(self, target, operator, waiting)
		return Search:Compare(operator, target.waiting, waiting)
	end
}
