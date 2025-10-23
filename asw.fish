function asw
    set -l conf_file $HOME/.config/asw/config.yaml
    set -l agent_file $HOME/.config/asw/agent

    # --- Helper: save current agent ---
    function _save_agent
        set -l file $argv[1]
        mkdir -p (dirname $file)
        echo "set -Ux AGENT_PROTOCOL $AGENT_PROTOCOL" > $file
        echo "set -Ux AGENT_URL $AGENT_URL" >> $file
        echo "set -Ux AGENT_KEY $AGENT_KEY" >> $file
        echo "set -Ux AGENT_MODEL $AGENT_MODEL" >> $file
        echo "set -Ux AGENT_PROVIDER $AGENT_PROVIDER" >> $file
    end

    # --- Helper: find current agent index ---
    function _find_current_index
        set -l conf_file $argv[1]
        set -l agents $argv[2..-1]
        set -l idx -1

        for i in (seq (count $agents))
            set -l name $agents[$i]
            set -l model (yq eval ".\"$name\".AGENT_MODEL" $conf_file)
            if test "$model" = "$AGENT_MODEL"
                set idx (math $i - 1)
                break
            end
        end

        if test $idx -lt 0
            set idx 0
        end

        echo $idx
    end

    # --- Helper: compute next/prev index safely ---
    function _compute_next_prev
        set -l cmd $argv[1]
        set -l idx $argv[2]
        set -l count $argv[3]

        if test "$cmd" = "next"
            echo (math "($idx + 1) % $count")
        else
            echo (math "($idx - 1 + $count) % $count")
        end
    end

    # --- Load current agent from file ---
    if test -f $agent_file
        source $agent_file
    end

    # --- Get all agent names (top-level YAML keys) ---
    set -l agents (yq eval 'keys | .[]' $conf_file)

    if test (count $agents) -eq 0
        echo "[asw] ⚠ No agents defined in $conf_file"
        return 1
    end

    # --- If no agent loaded, pick first one ---
    if not set -q AGENT_MODEL
        set -l first_agent $agents[1]
        for key in AGENT_PROTOCOL AGENT_URL AGENT_KEY AGENT_MODEL AGENT_PROVIDER
            set -U $key (yq eval ".\"$first_agent\".$key" $conf_file)
        end
        _save_agent $agent_file
    end

    # --- Command handling ---
    set -l cmd $argv[1]

    # Show all agents
    if test "$cmd" = "list" -o "$cmd" = "--list"
        echo "📜 Available Agents:"
        set -l current_model $AGENT_MODEL
        for i in (seq (count $agents))
            set -l name $agents[$i]
            set -l model (yq eval ".\"$name\".AGENT_MODEL" $conf_file)
            if test "$model" = "$current_model"
                echo -e (set_color green)" → [$i] $name ($model)"(set_color normal)
            else
                echo "   [$i] $name ($model)"
            end
        end
        return 0
    end

    # Switch next / prev
    if test "$cmd" = "next" -o "$cmd" = "prev"
        set -l idx (_find_current_index $conf_file $agents)
        set -l count (count $agents)
        set -l new_idx (_compute_next_prev $cmd $idx $count)
        set -l selected $agents[(math $new_idx + 1)]

        for key in AGENT_PROTOCOL AGENT_URL AGENT_KEY AGENT_MODEL AGENT_PROVIDER
            set -U $key (yq eval ".\"$selected\".$key" $conf_file)
        end

        _save_agent $agent_file

        echo (set_color cyan)"→ switched to $selected"(set_color normal)
    end

    # --- Show current agent ---
    echo "🐚 AGENT_MODEL=$AGENT_MODEL"
    echo "   AGENT_PROVIDER=$AGENT_PROVIDER"
    echo "   AGENT_URL=$AGENT_URL"
    echo "   AGENT_PROTOCOL=$AGENT_PROTOCOL"
end

