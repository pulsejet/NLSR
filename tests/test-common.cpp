/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2014-2022,  The University of Memphis,
 *                           Regents of the University of California
 *
 * This file is part of NLSR (Named-data Link State Routing).
 * See AUTHORS.md for complete list of NLSR authors and contributors.
 *
 * NLSR is free software: you can redistribute it and/or modify it under the terms
 * of the GNU General Public License as published by the Free Software Foundation,
 * either version 3 of the License, or (at your option) any later version.
 *
 * NLSR is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * NLSR, e.g., in COPYING.md file.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "tests/test-common.hpp"

#include <ndn-cxx/mgmt/nfd/control-parameters.hpp>

namespace nlsr {
namespace test {

std::shared_ptr<ndn::Data>
makeData(const ndn::Name& name)
{
  auto data = std::make_shared<ndn::Data>(name);
  return signData(data);
}

ndn::Data&
signData(ndn::Data& data)
{
  data.setSignatureInfo(ndn::SignatureInfo(ndn::tlv::NullSignature));
  data.setSignatureValue(std::make_shared<ndn::Buffer>());
  data.wireEncode();
  return data;
}

void
checkPrefixRegistered(const ndn::util::DummyClientFace& face, const ndn::Name& prefix)
{
  bool registerCommandEmitted = false;
  for (const auto& interest : face.sentInterests) {
    if (interest.getName().size() > 4 &&
        interest.getName().get(3) == ndn::name::Component("register")) {
      auto test = interest.getName().get(4);
      ndn::nfd::ControlParameters params(test.blockFromValue());
      if (params.getName() == prefix) {
        registerCommandEmitted = true;
        break;
      }
    }
  }
  BOOST_CHECK(registerCommandEmitted);
}

} // namespace test
} // namespace nlsr
