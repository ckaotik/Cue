local addonName, ns, _ = ...

--[[
	function oq.announce( msg, to_name, to_realm )
	  if ((msg == nil) or OQ_toon.disabled) then
	    return ;
	  end
	  if (to_name ~= nil) then
	    if (to_realm == player_realm) then
	      local msg_tok = "W".. oq.token_gen() ;
	      oq.token_push( msg_tok ) ;
	      m = "OQ,".. OQ_VER ..",".. msg_tok ..",".. OQ_TTL ..",".. msg ;
	      oq.SendAddonMessage( "OQ", m, "WHISPER", to_name ) ;
	      return ;
	    end
	    -- try to go direct if pid exists
	    local pid = oq.bnpresence( to_name .."-".. to_realm ) ;
	    if (pid ~= 0) then
	      local msg_tok = "W".. oq.token_gen() ;
	      oq.token_push( msg_tok ) ;
	      m = "OQ,".. OQ_VER ..",".. msg_tok ..",".. OQ_TTL ..",".. msg ;
	      oq.BNSendWhisper( pid, m, to_name, to_realm ) ;
	      return ;
	    end
	    -- if i have a bn-friend on the target realm, bnsend it to them and return
	    pid = oq.bnpresence_realm( to_realm ) ;
	    if (pid ~= 0) then
	      local msg_tok = "A".. oq.token_gen() ;
	      oq.token_push( msg_tok ) ;
	      m = "OQ,".. OQ_VER ..",".. msg_tok ..",".. OQ_TTL ..",".. msg ;
	      oq.BNSendWhisper( pid, m, to_name, to_realm ) ;
	      return ;
	    end

	    msg = msg ..",".. OQ_FLD_TO .."".. to_name ..",".. OQ_FLD_REALM .."".. tostring(oq.realm_cooked( to_realm )) ;
	  end
	  local msg_tok = "A".. oq.token_gen() ;
	  oq.token_push( msg_tok ) ;

	  local m = "OQ,".. OQ_VER ..",".. msg_tok ..",".. OQ_TTL ..",".. msg ;

	  -- send to raid (which sends to local channel and real-id ppl in the raid)
	  oq.announce_relay( m ) ;
	end
--]]
