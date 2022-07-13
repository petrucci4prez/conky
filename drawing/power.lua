local format = require 'format'
local pure = require 'pure'
local common = require 'common'
local geometry = require 'geometry'
local sys = require 'sys'

return function(update_freq, battery)
   local MODULE_Y = 380
   local TEXT_SPACING = 20
   local PLOT_SEC_BREAK = 20
   local PLOT_HEIGHT = 56
   local read_pkg0_joules = sys.intel_powercap_reader('intel-rapl:0')
   local read_dram_joules = sys.intel_powercap_reader('intel-rapl:0:2')

   local _read_battery_power = sys.battery_power_reader(battery)

   local read_battery_power = function(is_using_ac)
      if is_using_ac then
         return 0
      else
         return _read_battery_power()
      end
   end

   local power_label_function = function(plot_max)
      local fmt = common.y_label_format_string(plot_max, 'W')
      return function(watts) return string.format(fmt, watts) end
   end

   local format_rapl = function(watts)
      return format.precision_round_to_string(watts, 3)..' W'
   end

   local mk_static = function(obj)
      return pure.partial(common.tagged_scaled_timeseries_draw_static, obj)
   end

   local mk_dynamic = function(obj)
      return pure.partial(common.tagged_scaled_timeseries_draw_dynamic, obj)
   end

   local mk_rate_plot = function(label, read, y)
      local obj = common.make_rate_timeseries(
         geometry.RIGHT_X,
         y,
         geometry.SECTION_WIDTH,
         PLOT_HEIGHT,
         format_rapl,
         power_label_function,
         PLOT_SEC_BREAK,
         label,
         0,
         update_freq,
         read()
      )
      return common.mk_acc(
         PLOT_HEIGHT + PLOT_SEC_BREAK,
         function(_) common.update_rate_timeseries(obj, read()) end,
         mk_static(obj),
         mk_dynamic(obj)
      )
   end

   -----------------------------------------------------------------------------
   -- header

   local mk_header = pure.partial(
      common.mk_header,
      'POWER',
      geometry.SECTION_WIDTH,
      geometry.RIGHT_X
   )

   -----------------------------------------------------------------------------
   -- package 0 power plot

   local mk_pkg0 = pure.partial(mk_rate_plot, 'PKG0', read_pkg0_joules)

   -----------------------------------------------------------------------------
   -- DRAM power plot

   local mk_dram = pure.partial(mk_rate_plot, 'DRAM', read_dram_joules)

   -----------------------------------------------------------------------------
   -- battery power plot

   local format_ac = function(watts)
      if watts == 0 then
         return "A/C"
      else
         return format_rapl(watts)
      end
   end

   local mk_bat = function(y)
      local obj = common.make_tagged_scaled_timeseries(
         geometry.RIGHT_X,
         y,
         geometry.SECTION_WIDTH,
         PLOT_HEIGHT,
         format_ac,
         power_label_function,
         PLOT_SEC_BREAK,
         'Battery Draw',
         0,
         update_freq
      )
      return common.mk_acc(
         PLOT_HEIGHT + PLOT_SEC_BREAK,
         function(ac)
            common.tagged_scaled_timeseries_set(obj, read_battery_power(ac))
         end,
         mk_static(obj),
         mk_dynamic(obj)
      )
   end

   -----------------------------------------------------------------------------
   -- main functions

   local rbs = common.reduce_blocks_(
      MODULE_Y,
      {
         common.mk_block(mk_header, true, 0),
         common.mk_block(mk_pkg0, true, 0),
         common.mk_block(mk_dram, true, TEXT_SPACING),
         common.mk_block(mk_bat, true, TEXT_SPACING),
      }
   )

   return {
      static = rbs.static_drawer,
      dynamic = rbs.dynamic_drawer,
      update = rbs.updater
   }
end
