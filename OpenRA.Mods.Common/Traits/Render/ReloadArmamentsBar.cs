#region Copyright & License Information
/*
 * Copyright 2007-2017 The OpenRA Developers (see AUTHORS)
 * This file is part of OpenRA, which is free software. It is made
 * available to you under the terms of the GNU General Public License
 * as published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version. For more
 * information, see COPYING.
 */
#endregion

using System;
using System.Drawing;
using System.Linq;
using OpenRA.Traits;

namespace OpenRA.Mods.Common.Traits.Render
{
	[Desc("Visualizes the remaining time for a condition.")]
	class ReloadArmamentsBarInfo : ITraitInfo
	{
		[Desc("Armament names")]
		public readonly string[] Armaments = { "primary", "secondary" };

		public readonly Color Color = Color.Red;

		public object Create(ActorInitializer init) { return new ReloadArmamentsBar(init.Self, this); }
	}

	class ReloadArmamentsBar : ISelectionBar
	{
		readonly ReloadArmamentsBarInfo info;
		readonly Actor self;
		readonly Lazy<Armament[]> armaments;

		public ReloadArmamentsBar(Actor self, ReloadArmamentsBarInfo info)
		{
			this.self = self;
			this.info = info;

			armaments = Exts.Lazy(() => self.TraitsImplementing<Armament>()
				.Where(a => info.Armaments.Contains(a.Info.Name)).ToArray());
		}

		float ISelectionBar.GetValue()
		{
			if (!self.Owner.IsAlliedWith(self.World.RenderPlayer))
				return 0;

			int count = 0;
			float sum = 0;

			foreach (var armament in armaments.Value)
			{
				sum += 1 - (armament.FireDelay / (float)armament.Weapon.ReloadDelay);
				count++;
			}

			return count > 0 ? sum / count : 0;
		}

		Color ISelectionBar.GetColor() { return info.Color; }
		bool ISelectionBar.DisplayWhenEmpty { get { return false; } }
	}
}
