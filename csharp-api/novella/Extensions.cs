using System;

namespace nv {
	public static class Extensions {
		public static string toFunctionName(this Guid id) {
			return "_" + id.ToString().Replace("-", "");
		}

		public static string toVariableName(this Guid id) {
			return "var_" + id.ToString().Replace("-", "");
		}
	}
}