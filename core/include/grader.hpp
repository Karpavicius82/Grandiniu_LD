#pragma once
#include "json.hpp"
#include "ldcore.hpp"
namespace ld {
using Json=nlohmann::json;
Json read_report(const std::filesystem::path&);
Json grade(const Json&);
std::string html_escape(const std::string&);
}
